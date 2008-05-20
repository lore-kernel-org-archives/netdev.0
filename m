From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: WARNING: at net/ipv4/tcp_input.c:2539 tcp_ack+0xd2b/0x191f()
Date: Tue, 20 May 2008 16:28:07 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805191152390.16829@wrl-59.cs.helsinki.fi>
References: <651806990805170819j5fdd42eeq805bfc31776ac897@mail.gmail.com>
 <Pine.LNX.4.64.0805172345440.17738@wrl-59.cs.helsinki.fi>
 <651806990805190057u74f81630l9801b90c2613ed47@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: int 986 <int986@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:52823 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758695AbYETN2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 09:28:09 -0400
In-Reply-To: <651806990805190057u74f81630l9801b90c2613ed47@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 19 May 2008, int 986 wrote:

> thank you for detailed explanation. Debug patch is unlikely to test on our
> live servers, but i can stress test it on our test servers.

Thanks, please take the latest debug patch from here:

  http://marc.info/?l=linux-netdev&m=120972551120080&w=2

Please make sure you have log enough buffer for kernel messages while 
testing (CONFIG_LOG_BUF_SHIFT) so that the disaster of the last time 
doesn't repeat... :-)

> We have farm with web servers for static content delivery and live
> streaming. Our servers are from the tiny one with two disks to large systems
> with 96 disks and external arrays. On every server we are using lighttpd
> 1.5svn and linux 2.6.25.3. This warning we are seeing on every server in our
> farm. I don't think that bug is connected to network setup may be is
> connected to lighttpd - because we are in six different co-locations and
> every co-location has your own network setup :)

Yeah, you may well be right, it could well be something else on the 
end-to-end path which causes it to trigger. ...I was just trying to find
a common denominator as the other guy has a setup which is know to reorder 
things.

-- 
 i.
