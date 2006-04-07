From: Mark Butler <butlerm@middle.net>
Subject: Re: Broadcast ARP packets on link local addresses (Version2).
Date: Fri, 07 Apr 2006 14:38:42 -0600
Message-ID: <4436CDD2.7010303@middle.net>
References: <17460.13568.175877.44476@dl2.hq2.avtrex.com>	 <priv$efbe06144502$2d51735f79@200604.gmail.com>	 <44353F36.9070404@avtrex.com> <1144416638.5082.33.camel@jzny2> <443690C9.5090500@avtrex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Janos Farkas <chexum+dev@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pgf@foxharp.boston.ma.us, freek@macfreek.nl
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964947AbWDGUim@vger.kernel.org>
To: David Daney <ddaney@avtrex.com>
In-Reply-To: <443690C9.5090500@avtrex.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Daney wrote:

> Following your logic through, It seems that you are advocating 
> broadcasting *all* ARP packets on *all* link local addresses.  That 
> would mean that on a 192.168.* switched Ethernet network with DHCP 
> that twice as many ARP packets would be broadcast.

192.168.* addresses are not considered "link local", they are rather 
"private" or "site local" addresses.

> The scope parameter, as far as I can tell, is used to make routing 
> decisions.  Overloading it to also implement the RFC 3927 ARP 
> broadcasting requirement would result in generation of unnecessary 
> network traffic in configurations that are probably the majority of 
> Linux deployments.

No extra network traffic, but there is some measurable overhead to 
looking up the scope in the routing table.

One problem is having this type of scheme behave properly by default, 
i.e. in the absence of user specified entries.  Having to create an 
entry for every interface in the system just to get RFC standard 
behavior is silly.

- Mark
