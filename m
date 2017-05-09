From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v7 0/5] skb_to_sgvec hardening
Date: Tue, 9 May 2017 16:08:56 +0200
Message-ID: <CAHmME9rB3RbSBOkjmqHv-uO9eHEEhLXZf_Q5_hZ7jiLhzpo_Wg@mail.gmail.com>
References: <20170509135009.13751-1-Jason@zx2c4.com> <1494338600.2410.6.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, kernel-hardening@lists.openwall.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <kernel-hardening-return-7785-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1494338600.2410.6.camel@sipsolutions.net>
List-Id: netdev.vger.kernel.org

On Tue, May 9, 2017 at 4:03 PM, Johannes Berg <johannes@sipsolutions.net> wrote:
> Perhaps you should add __must_check annotation to the function
> prototype(s)?

Great idea. I've started doing this in my own code. Wasn't sure how
popular it was outside of there, but I'm glad to hear a suggestion of
it now. I'll have this in v8.
