From: "Amar Mudrankit" <amar.mudrankit@qlogic.com>
Subject: Re: [ofa-general] Re: [PATCH v4 14/14] QLogic VNIC: sysfs Documentation
Date: Sat, 14 Jun 2008 03:17:08 +0530
Message-ID: <c8028d330806131447t2b24be93sa0e07bfa792c8f7f@mail.gmail.com>
References: <20080610205633.11186.45499.stgit@dale>
	 <20080610210918.11186.64253.stgit@dale> <484F751F.7030407@trash.net>
	 <71d336490806120850x3b5e6172jf4d75850771d6349@mail.gmail.com>
	 <485148DA.2060508@trash.net>
	 <c8028d330806121409x27a4d596k571ce87934e89371@mail.gmail.com>
	 <48529027.1090309@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com,
	general@lists.openfabrics.org, poornima.kamath@qlogic.com
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.225]:36906 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754065AbYFMVrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2008 17:47:08 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2743191rvb.1
        for <netdev@vger.kernel.org>; Fri, 13 Jun 2008 14:47:08 -0700 (PDT)
In-Reply-To: <48529027.1090309@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> If you have questions, feel free to ask.
>
I was trying to guess the use case for the vlan which has implemented
rtnl_link api :

For sending parameters to driver:
# ip link set <vlan-iface-name> up multicast ...... type vlan id
<vlan-id> reorder_hdr on

ingress-qos-map <...> egress-qos-map <...>

In such case, I think the link_util's private parse_opt function will
be invoked to parse link's private configurable parameters.  These
parameters along with the standard set of parameters (name, multicast,
promisc etc) are then sent to driver through rtnl_talk function .

Similarly, for reading values from driver:

# ip addr show dev <vlan-iface-name>

does it require "type" field similar to "ip link set"?

Is this understanding correct?

How does a link type corresponding to VLAN driver gets added into
linkutil_list, so that ip will correctly call functions specific to
VLAN driver?

>
> You can dump driver private statistics in the ->fill_xstats function.
>

I was looking at latest release of iproute2, in which I could not
locate fill_xstats. Can you help me to locate this?

Thanks and Regards,
Amar
