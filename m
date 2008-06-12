From: Patrick McHardy <kaber@trash.net>
Subject: Re: [ofa-general] Re: [PATCH v4 14/14] QLogic VNIC: sysfs Documentation
Date: Thu, 12 Jun 2008 17:18:38 +0200
Message-ID: <48513E4E.4040601@trash.net>
References: <20080610205633.11186.45499.stgit@dale>	 <20080610210918.11186.64253.stgit@dale> <484F751F.7030407@trash.net> <c8028d330806120813q6363c3cemb4aa03ceff6547d1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>,
	netdev@vger.kernel.org, rdreier@cisco.com,
	general@lists.openfabrics.org, poornima.kamath@qlogic.com
To: Amar Mudrankit <amar.mudrankit@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42673 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750699AbYFLPSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 11:18:42 -0400
In-Reply-To: <c8028d330806120813q6363c3cemb4aa03ceff6547d1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Amar Mudrankit wrote:
>>> +/sys/class/infiniband_qlgc_vnic/interfaces/<VNIC-interface-name>/
>>> +
>>> +       vnic_state      (0444)  State of the VNIC interface.
>> This I don't understand - you seem to be registering and
>> unregistering the net_device based some state machine,
>> in some cases even triggered by timers.
>>
>> Whats the idea behind this?
> 
> For a given VNIC interface, unless the VNIC host driver establishes a
> connection with EVIC
> and completes the control and data path communication sequence with
> the EVIC, the
> VNIC network device is not registered on the host.  Establishing a
> connection with EVIC
> and going through the control and data path communication involves
> multiple packet
> exchange on the IB side with the EVIC and can take some time.  The
> netpath statemachine is, hence, meant to PERIODICALLY check if
> connection is fully established with EVIC or not.
> Once connection is established, it takes care to register the VNIC netdevice.


We have linkstate/operstate for this. How is a user supposed
to configure the network device when it appears at a more or
less random time from his perspective?

