From: "Dave, Tushar N" <tushar.n.dave@intel.com>
Subject: RE: [net-next 02/11] e1000: Adding e1000_dump function
Date: Wed, 8 Feb 2012 18:39:30 +0000
Message-ID: <061C8A8601E8EE4CA8D8FD6990CEA89123BDE6@ORSMSX102.amr.corp.intel.com>
References: <1328618038-5008-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1328618038-5008-3-git-send-email-jeffrey.t.kirsher@intel.com>
 <1782836.alj52xdzPl@alaris>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jbeulich@suse.com" <jbeulich@suse.com>
To: Michal Kubecek <mkubecek@suse.cz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:43602 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751197Ab2BHSjh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 13:39:37 -0500
In-Reply-To: <1782836.alj52xdzPl@alaris>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Michal Kube=E8ek [mailto:mkubecek@suse.cz]
>Sent: Tuesday, February 07, 2012 9:38 AM
>To: netdev@vger.kernel.org
>Cc: Kirsher, Jeffrey T; davem@davemloft.net; Dave, Tushar N;
>gospo@redhat.com; sassmann@redhat.com; jbeulich@suse.com
>Subject: Re: [net-next 02/11] e1000: Adding e1000_dump function
>
>On Tuesday 07 of February 2012 04:33EN, Jeff Kirsher wrote:
>> +		if (netif_msg_pktdata(adapter) && buffer_info->dma !=3D 0)
>> +			print_hex_dump(KERN_INFO, "", DUMP_PREFIX_ADDRESS,
>> +					16, 1, phys_to_virt(buffer_info->dma),
>> +					buffer_info->length, true);
>
>This might cause problems in Xen environment, we encountered a crash i=
n
>e1000e where phys_to_virt() is used the same way. I'm not familiar wit=
h
>the details but this is what Jan Beulich wrote about it:

How did you fix the problem in e1000e then? I don't see bus_to_virt use=
d in any of our Ethernet drivers.
Also when running in Xen which arch are you running on?

-Tushar
