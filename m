From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC/PATCH] IMQ port to 2.6
Date: 25 Jan 2004 18:45:16 -0500
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <1075074316.1747.115.camel@jzny.localdomain>
References: <20040125152419.GA3208@penguin.localdomain>
	 <20040125164431.GA31548@louise.pinerecords.com>
	 <1075058539.1747.92.camel@jzny.localdomain>
	 <20040125202148.GA10599@usr.lcm.msu.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: "Vladimir B. Savkin" <master@sectorb.msk.ru>
In-Reply-To: <20040125202148.GA10599@usr.lcm.msu.ru>
List-Id: netdev.vger.kernel.org

On Sun, 2004-01-25 at 15:21, Vladimir B. Savkin wrote:
> On Sun, Jan 25, 2004 at 02:22:19PM -0500, jamal wrote:

> Think multiple clients connected via PPP. I want to shape traffic,
> so ingress is out of question. I want different clients in a same

Ok, 
a) why do you want to shape on ingress instead of policing?
OR
b) Why cant you achieve the same results by marking on ingress and
shaping on egress? 

> htb class, so using qdisc on each ppp interface is out of
> question. It seems to me that IMQ is the only way to achieve my goals.

By multiple clients i believe you mean you want to say "-i ppp+"?
We had a long discussion on this a while back (search netdev) 
and i think it is a valid point for dynamic devices like ppp. 
We need to rethink how we do things. Theres a lot of valu in having per
device tables (scalability being one).
IMO, this alone does not justify the existence of IMQ. 
We should do this (and other things) right, maybe a sync with the
netfilter folks will be the right thing to do. 

cheers,
jamal
