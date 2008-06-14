From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [0/3] POHMELFS high performance network filesystem. First steps
 in parallel processing.
Date: Sat, 14 Jun 2008 05:52:38 -0400
Message-ID: <485394E6.9080809@garzik.org>
References: <20080613163700.GA25860@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20080613163700.GA25860@2ka.mipt.ru>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> Hi.
> 
> I'm pleased to announce POHMEL high performance network parallel
> distributed filesystem.
> POHMELFS stands for Parallel Optimized Host Message Exchange Layered File System.
> 
> Development status can be tracked in filesystem section [1].
> 
> This is a high performance network filesystem with local coherent cache of data
> and metadata. Its main goal is distributed parallel processing of data.
> 
> This release brings following features:
>  * Read requests (data read, directory listing, lookup requests) balancing
>  	between multiple servers.
>  * Write requests are sent to multiple servers and completed only
>  	when all of them sent an ack.
>  * Ability to add and/or remove servers from working set at run-time from
> 	 userspace (via netlink, so the same command can be processed from
> 	 real network though, but since server does not support it yet,
> 	 I dropped network part).
>  * Documentation (overall view and protocol commands)!
>  * Rename command (oops, forgot it in previous releases :)
>  * Several new mount options to control client behaviour instead of
> 	hardcoded numbers.
>  * Bug fixes.

Neat :)  Thanks for protocol documentation, too.  Do you plan to add 
write-pages in addition to write-page?  Also, write-page does not appear 
to be documented.

Is race-across-directories race-free?  That is a sticky area, see 
Documentation/filesystems/directory-locking in particular.

With the exception of encryption, do you think the POHMELFS client is 
mostly complete, at this point?

	Jeff


