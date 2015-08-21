From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: DEBUG_LOCKS_WARN_ON(in_interrupt()) triggering in socket code
Date: Fri, 21 Aug 2015 15:42:33 +0200
Message-ID: <CAHmME9pXVdT5aDcf04QUQbrjTh4LpsqcWJeS1Etjf_2E08GM2w@mail.gmail.com>
References: <CAHmME9p06qf36RPtROF767c5p37PggN12bSa9u8ZXgGGThA4BQ@mail.gmail.com>
	<CAHmME9qfvVbDuadThepz_37esYu-kFiUOeVoxpEmFn9doiEctg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHmME9qfvVbDuadThepz_37esYu-kFiUOeVoxpEmFn9doiEctg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ahhh, interesting, so it turns out you can't do a number of things
with a read_lock_bh held, because it increases the softirq count.
Mystery solved.
