From: Joe Eykholt <jeykholt@cisco.com>
Subject: Re: [PATCH] Consolidate shared code between enic and fnic drivers.
Date: Tue, 23 Jun 2009 16:53:38 -0700
Message-ID: <4A416B02.2040607@cisco.com>
References: <C65FC516.7747%scofeldm@cisco.com> <4A3A7D4B.5050204@cs.wisc.edu> <adazlbyoe7l.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mike Christie <michaelc@cs.wisc.edu>,
	Scott Feldman <scofeldm@cisco.com>,
	Hannes Reinecke <hare@suse.de>,
	James.Bottomley@HansenPartnership.com, davem@davemloft.net,
	gospo@redhat.com, abjoglek@cisco.com, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <adazlbyoe7l.fsf@cisco.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roland Dreier wrote:
>  > For the includes then, do we put them in include/shared/cisco_vnic or
>  > do we do that EXTRA_CFLAGS += -Idrivers/shared/cisco_vnic? In that
>  > patch for fnic/vnic/enic I sent a while back I did the EXTRA_CFLAGS,
>  > only because that is how cxgb3/iw_cxgb3 was doing it. I am not sure if
>  > that is nice or not. It was on the TODO to check it out.
> 
> For mlx4, I created include/linux/mlx4/.
> 
> Maybe create include/shared and move to that?

Or how about include/drivers/mlx4 and similarly for cisco_vnic
(but we're leaning towards cvnic)?

include/drivers seems more like a generally useful subdirectory
with some meaning.   include/shared leaves one guessing as to what
it might be.
	
	Joe
