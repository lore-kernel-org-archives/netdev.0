From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH -next v2] unix stream: Fix use-after-free crashes
Date: Sun, 04 Sep 2011 08:50:10 -0700
Message-ID: <1315151411.10088.2.camel@Joe-Laptop>
References: <4E631032.6050606@intel.com>
	 <CA+icZUU25QMMCVT1VfF9XB0wrkppNmKQbHwoHDAQ-qV9bi+HqQ@mail.gmail.com>
	 <CAAM7YAk0csJLLVFF6KYA8vMG_BN6QDvmYvtnY0Sq7P=cBsuKfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sedat.dilek@gmail.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"tim.c.chen@linux.intel.com" <tim.c.chen@linux.intel.com>,
	"jirislaby@gmail.com" <jirislaby@gmail.com>
To: "Yan, Zheng" <zheng.z.yan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:50871 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751026Ab1IDPuM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Sep 2011 11:50:12 -0400
In-Reply-To: <CAAM7YAk0csJLLVFF6KYA8vMG_BN6QDvmYvtnY0Sq7P=cBsuKfg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-09-04 at 16:23 +0800, Yan, Zheng wrote:
> On Sun, Sep 4, 2011 at 3:12 PM, Sedat Dilek <sedat.dilek@googlemail.com> wrote:
> > On Sun, Sep 4, 2011 at 7:44 AM, Yan, Zheng <zheng.z.yan@intel.com> wrote:
> >> It passes the scm reference to the first skb. Skb(s) afterwards may
> >> reference freed data structure because the first skb can be destructed
> >> by the receiver at anytime. The fix is by passing the scm reference to
> >> the very last skb.
> > s/by passing/bypassing ?
> No

(putting on my Randy Dunlap hat)

The issue was fixed by passing...
or maybe
The fix is to pass...
