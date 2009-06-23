From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH] Consolidate shared code between enic and fnic drivers.
Date: Tue, 23 Jun 2009 14:03:10 -0700
Message-ID: <adazlbyoe7l.fsf@cisco.com>
References: <C65FC516.7747%scofeldm@cisco.com> <4A3A7D4B.5050204@cs.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <scofeldm@cisco.com>, Hannes Reinecke <hare@suse.de>,
	James.Bottomley@HansenPartnership.com, davem@davemloft.net,
	gospo@redhat.com, abjoglek@cisco.com, jeykholt@cisco.com,
	netdev@vger.kernel.org, linux-scsi@vger.kernel.org
To: Mike Christie <michaelc@cs.wisc.edu>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <4A3A7D4B.5050204@cs.wisc.edu> (Mike Christie's message of "Thu,
	18 Jun 2009 12:45:47 -0500")
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


 > For the includes then, do we put them in include/shared/cisco_vnic or
 > do we do that EXTRA_CFLAGS += -Idrivers/shared/cisco_vnic? In that
 > patch for fnic/vnic/enic I sent a while back I did the EXTRA_CFLAGS,
 > only because that is how cxgb3/iw_cxgb3 was doing it. I am not sure if
 > that is nice or not. It was on the TODO to check it out.

For mlx4, I created include/linux/mlx4/.

Maybe create include/shared and move to that?

 - R.
