From: Joseph Salisbury <joseph.salisbury@canonical.com>
Subject: Re: [PATCH][v3.18.y][v3.19.y]  tg3: Hold tp->lock before calling
 tg3_halt() from tg3_init_one()
Date: Fri, 06 Mar 2015 15:17:28 -0500
Message-ID: <54FA0B58.3040806@canonical.com>
References: <54F8CDDE.6090002@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: prashant@broadcom.com, mchan@broadcom.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54F8CDDE.6090002@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/05/2015 04:42 PM, Joseph Salisbury wrote:
> Hello,
>     
> Please consider including mainline commit
> d0af71a3573f1217b140c60b66f1a9b335fb058b in the next v3.18.y and v3.19.y
> stable releases.  It was included in the mainline tree as of v4.0-rc1. 
> It has been tested and confirmed to resolve:
> http://bugs.launchpad.net/bugs/1428111 .
>
> This commit fixes a regression introduced going from 3.16 to 3.19, so it
> may not be needed in earlier than 3.18 stable releases.
>
> commit d0af71a3573f1217b140c60b66f1a9b335fb058b
> Author: Jun'ichi Nomura \(NEC\) <j-nomura@ce.jp.nec.com>
> Date:   Thu Feb 12 01:26:24 2015 +0000
>
>     tg3: Hold tp->lock before calling tg3_halt() from tg3_init_one()
>
>
> Sincerely,
> Joseph Salisbury
>
>

After some further testing, it looks like only 3.19 is affected by the
bug.  The upstream 3.18.y stable kernel does not require the commit.

Thanks,

Joe
