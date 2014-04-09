From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Does IPv6 support Jumbograms ?
Date: Wed, 09 Apr 2014 14:41:05 -0700
Message-ID: <1397079665.16584.17.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5345A2B3.7040602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois WELLENREITER <f.wellenreiter@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:57647 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964976AbaDIVlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2014 17:41:09 -0400
Received: by mail-pd0-f173.google.com with SMTP id z10so2966480pdj.4
        for <netdev@vger.kernel.org>; Wed, 09 Apr 2014 14:41:09 -0700 (PDT)
In-Reply-To: <5345A2B3.7040602@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-04-09 at 21:42 +0200, Francois WELLENREITER wrote:
> Hi there,
> 
> I've been recently running performance tests with the loopback interface
> increasing the MTU over the 65535 byte limit.
> I was really surprised to see that a simple scp onto the ::1 address
> systematically blocked after transferring about 2,4 MB.
> My interpretation of this behavior is that the current IPv6 kernel layer
> does not support Jumbograms at all. Am I wrong ?
> If that's not the case, what could then the right interpretation of this
> issue ?
> And whenever I'm right, is there any plan to support this feature in a
> near future ?

What do you mean by blocked ?

Please give more details (kernel version, exact mtu...), because it
should not happen !

# ifconfig lo mtu 100000
# scp -6 vmlinux edumazet@ip6-localhost:/tmp
Password: 
vmlinux
100%   24MB  23.5MB/s   00:00    
# ls -l /tmp/vmlinux
-rwxr-xr-x 1 edumazet eng 24668915 Apr  9 14:37 /tmp/vmlinux
