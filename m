From: Henrik Nordstrom <hno@marasystems.com>
Subject: Re: NFS and Network Driver Question
Date: Thu, 21 Oct 2004 18:17:17 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.61.0410211816450.26120@filer.marasystems.com>
References: <41704198.8000206@rtcworks.com> <4175AEFE.7090002@rtcworks.com>
 <41768B15.1090402@osdl.org> <4177D115.5070205@rtcworks.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com,
        linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Bob Wirka <bobwirka@rtcworks.com>
In-Reply-To: <4177D115.5070205@rtcworks.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 21 Oct 2004, Bob Wirka wrote:

> The kernel configuration is identical, except for kernel IP 
> autoconfiguration, root over nfs, and compiled-in network driver. The NFS 
> configuration on the host has 'no_root_squash', and <<now>> all the files on 
> the host root file system are owned by root.

Double check the routing tables

   ip ro ls table 0

give you all of them...

Regards
Henrik
