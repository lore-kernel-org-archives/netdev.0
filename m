From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 06/12] ixgbe: Hardware Timestamping + PTP Hardware
 Clock (PHC)
Date: Tue, 15 May 2012 07:32:17 +0200
Message-ID: <20120515053216.GA2708@netboy.at.omicron.at>
References: <1336632413-19135-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1336632413-19135-7-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120510141122.GB3392@localhost.localdomain>
 <02874ECE860811409154E81DA85FBB580779423F@ORSMSX105.amr.corp.intel.com>
 <20120511051509.GA2170@netboy.at.omicron.at>
 <02874ECE860811409154E81DA85FBB58077949E8@ORSMSX105.amr.corp.intel.com>
 <20120512053458.GC2190@netboy.at.omicron.at>
 <4FB18A3B.8030308@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Jacob Keller <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:50525 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751416Ab2EOFc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2012 01:32:27 -0400
Received: by wibhn6 with SMTP id hn6so3170207wib.1
        for <netdev@vger.kernel.org>; Mon, 14 May 2012 22:32:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4FB18A3B.8030308@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 14, 2012 at 03:42:03PM -0700, Jacob Keller wrote:
> 
> sk_run_filter is always returning PTP_CLASS_NONE (0), instead of the
> correct type. Do you know what I am doing wrong? I can send you the
> patch I am working with...

The filter need to run with a pointer to the DST MAC. Perhaps you are
passing it the address of padding or Layer 3?

I will take a look at the patch...

Thanks,
Richard
