From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 2/3] cnic: Add CNIC driver.
Date: Fri, 23 May 2008 13:09:13 -0700
Message-ID: <adalk207pg6.fsf@cisco.com>
References: <1211418386-18203-1-git-send-email-mchan@broadcom.com>
	<1211418386-18203-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, michaelc@cs.wisc.edu, anilgv@broadcom.com,
	netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	open-iscsi@googlegroups.com
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1211418386-18203-3-git-send-email-mchan@broadcom.com> (Michael
	Chan's message of "Wed, 21 May 2008 18:06:25 -0700")
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > +config CNIC
 > +	tristate "Broadcom CNIC support"
 > +	depends on BNX2

I suspect you'll need a "depends on INET" somewhere (probably here, but
maybe only for the iSCSI part).

 - R.
