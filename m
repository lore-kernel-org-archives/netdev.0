From: James Smart <James.Smart@Emulex.Com>
Subject: Re: [RFC] Netlink and user-space buffer pointers
Date: Wed, 19 Apr 2006 13:05:37 -0400
Message-ID: <44466DE1.4080409@emulex.com>
References: <1145306661.4151.0.camel@localhost.localdomain>	<20060418160121.GA2707@us.ibm.com>	<444633B5.5030208@emulex.com> <20060419092645.29cb0420@localhost.localdomain>
Reply-To: James.Smart@Emulex.Com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060419092645.29cb0420@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Stephen Hemminger wrote:
> On Wed, 19 Apr 2006 08:57:25 -0400
> James Smart <James.Smart@Emulex.Com> wrote:
> 
>> Folks,
>>
>> To take netlink to where we want to use it within the SCSI subsystem (as
>> the mechanism of choice to replace ioctls), we're going to need to pass
>> user-space buffer pointers.
> 
> This changes the design of netlink. It is desired that netlink
> can be done remotely over the network as well as queueing.
> The current design is message based, not RPC based. By including a
> user-space pointer, you are making the message dependent on the
> context as it is process.
> 
> Please rethink your design.

I assume that the message receiver has some way to determine where the
message originated (via the sk_buff), and thus could reject it if it
didn't meet the right criteria.  True ?  You just have to be cognizant
that it is usable from a remote entity - which is a very good thing.
