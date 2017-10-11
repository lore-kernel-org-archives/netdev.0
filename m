From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v3] mac80211: aead api to reduce redundancy
Date: Wed, 11 Oct 2017 09:48:02 +0200
Message-ID: <1507708082.1998.9.camel@sipsolutions.net>
References: <20171011023149.18021-1-qasdfgtyuiop@gmail.com>
         (sfid-20171011_043254_406148_2E5F049A)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Xiang Gao <qasdfgtyuiop@gmail.com>, davem@davemloft.net,
        linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171011023149.18021-1-qasdfgtyuiop@gmail.com> (sfid-20171011_043254_406148_2E5F049A)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-10-10 at 22:31 -0400, Xiang Gao wrote:
> Currently, the aes_ccm.c and aes_gcm.c are almost line by line copy
> of
> each other. This patch reduce code redundancy by moving the code in
> these
> two files to crypto/aead_api.c to make it a higher level aead api.
> The
> file aes_ccm.c and aes_gcm.c are removed and all the functions there
> are
> now implemented in their headers using the newly added aead api.

Applied. FWIW, the sta_dynamic_down_up test that the robot complained
about, and the PSK tests that heavily use CCMP all pass.

johannes
