From: Xiang Gao <qasdfgtyuiop@gmail.com>
Subject: Re: [PATCH v3] mac80211: aead api to reduce redundancy
Date: Wed, 11 Oct 2017 10:12:30 -0400
Message-ID: <CAMtaSwRNc0JvyG04SpW2DxNyzdCtwE0o0i2biMF6Wm+53NHmDg@mail.gmail.com>
References: <20171011023149.18021-1-qasdfgtyuiop@gmail.com> <1507708082.1998.9.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507708082.1998.9.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Great ! Thanks !
Xiang Gao


2017-10-11 3:48 GMT-04:00 Johannes Berg <johannes@sipsolutions.net>:
> On Tue, 2017-10-10 at 22:31 -0400, Xiang Gao wrote:
>> Currently, the aes_ccm.c and aes_gcm.c are almost line by line copy
>> of
>> each other. This patch reduce code redundancy by moving the code in
>> these
>> two files to crypto/aead_api.c to make it a higher level aead api.
>> The
>> file aes_ccm.c and aes_gcm.c are removed and all the functions there
>> are
>> now implemented in their headers using the newly added aead api.
>
> Applied. FWIW, the sta_dynamic_down_up test that the robot complained
> about, and the PSK tests that heavily use CCMP all pass.
>
> johannes
