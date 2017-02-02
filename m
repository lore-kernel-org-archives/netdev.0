From: Adrian Chadd <adrian@freebsd.org>
Subject: Re: [PATCH 1/3] ath10k: remove ath10k_vif_to_arvif()
Date: Thu, 2 Feb 2017 08:17:00 -0800
Message-ID: <CAJ-VmonrHpS3MArM9ohHgLvb6xspP_gnVVeJWA9F-pjUpJ+LZA@mail.gmail.com>
References: <1486030773-30600-1-git-send-email-amadeusz.slawinski@tieto.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "ath10k@lists.infradead.org" <ath10k@lists.infradead.org>,
        Kalle Valo <kvalo@qca.qualcomm.com>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        netdev@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: =?UTF-8?B?QW1hZGV1c3ogU8WCYXdpxYRza2k=?=
        <amadeusz.slawinski@tieto.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486030773-30600-1-git-send-email-amadeusz.slawinski@tieto.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hiya,

Removing this method makes the diff to FreeBSD larger, as "vif" in
FreeBSD is a different pointer.

(Yes, I have ath10k on freebsd working and I'd like to find a way to
reduce the diff moving forward.)



-adrian
