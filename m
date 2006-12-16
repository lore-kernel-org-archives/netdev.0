From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH 2.6.18 2/2] LARTC: trace control for netem: kernelspace
Date: Sat, 16 Dec 2006 16:11:41 +0100
Message-ID: <20061216151141.GB3641@c3po.0xdef.net>
References: <45827B60.4010809@tik.ee.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@VGER.KERNEL.ORG,
	netem@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
To: Rainer Baumann <baumann@tik.ee.ethz.ch>
Content-Disposition: inline
In-Reply-To: <45827B60.4010809@tik.ee.ethz.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Rainer Baumann | 2006-12-15 11:39:28 [+0100]:

>Patch for linux kernel 2.6.18.13:
>http://tcn.hypert.net/tcn_kernel_configfs.patch

This patch isn't ok ( maybe this patch benefit from gcc padding behaviours):

static struct pktdelay get_next_delay(struct netem_sched_data *q)
{
  struct pktdelay retval;

  [...]

  return retval;
}

There are also some tiny coding style issues.


Hagen

PS: please setup you mua to break lines - it's a little bit difficult to read
you mails
