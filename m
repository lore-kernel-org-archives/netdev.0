From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [ANNOUNCE] netplug, a daemon that handles network cables getting
 plugged in and out
Date: Thu, 28 Aug 2003 18:34:27 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <3F4E8373.1040204@pobox.com>
References: <1062105712.12285.78.camel@serpentine.internal.keyresearch.com> <20030828215417.GA22215@werewolf.able.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bryan O'Sullivan <bos@keyresearch.com>,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: "J.A. Magallon" <jamagallon@able.es>
In-Reply-To: <20030828215417.GA22215@werewolf.able.es>
List-Id: netdev.vger.kernel.org

J.A. Magallon wrote:
> On 08.28, Bryan O'Sullivan wrote:
> 
>>Netplug is a daemon that responds to network cables being plugged in or
>>out by bringing a network interface up or down.  This is extremely
>>useful for DHCP-managed systems that move around a lot, such as laptops
>>and systems in cluster environments.
>>
>>For more details and download instructions, see the netplug homepage:
>>http://www.red-bean.com/~bos/
>>
> 
> 
> I feel sorry, but did you ever knew this existed ?
> 
> http://www.stud.uni-hamburg.de/users/lennart/projects/ifplugd/


ifplugd doesn't appear to use netlink.  Did I miss something?

netlink is definitely the preferred way to get link notification.  Maybe 
the two authors can work together to merge the best parts of both...

	Jeff
