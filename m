From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: Re: [target-pending 00/12] cxgb4 patch series for cxgbit.ko
Date: Mon, 14 Mar 2016 22:29:11 -0700
Message-ID: <1458019751.15882.31.camel@haakon3.risingtidesystems.com>
References: <cover.1457877852.git.varun@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: target-devel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, swise@opengridcomputing.com,
	indranil@chelsio.com, kxie@chelsio.com, hariprasad@chelsio.com
To: Varun Prakash <varun@chelsio.com>
Return-path: <target-devel-owner@vger.kernel.org>
In-Reply-To: <cover.1457877852.git.varun@chelsio.com>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Varun & Co,

On Sun, 2016-03-13 at 19:49 +0530, Varun Prakash wrote:
> Hi Nicholas,
> 
>    I am posting cxgb4 patch series as
>    suggested by you in following email thread
> 
>    http://www.spinics.net/lists/target-devel/msg12437.html
> 
>    This series consists of patches from
>    initial cxgb4 series without any change.
> 
> Thanks
> Varun
> 

Thanks for re-posting iscsi segment offload (ISO) prerequisites as a
stand-alone vxgb4 network driver series.

This -v1 series has been in target-pending/for-next-merge for last
weeks, and encountered one conflict vs. net-next as reported by SFR:

  https://lkml.org/lkml/2016/2/29/34 

That said, I'm still OK to merge via target-pending to enable post v4.6
iscsi-target developments, as long as DaveM doesn't have an objection or
if he'd prefer to pick them up.

As-is, they still need Acked-by's from the cxgb4 driver maintainer.  

Hariprasad, please give your review + ack.
