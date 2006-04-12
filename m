From: Andy Furniss <andy.furniss@dsl.pipex.com>
Subject: Re: Window shrinking (was Linux v2.6.16-rc6)
Date: Thu, 13 Apr 2006 00:34:22 +0100
Message-ID: <443D8E7E.4080909@dsl.pipex.com>
References: <Pine.LNX.4.64.0603111551330.18022@g5.osdl.org>	<6bffcb0e0603111751i1ed30794s@mail.gmail.com> <20060311.183904.71244086.davem@davemloft.net> <4438F952.5040802@dsl.pipex.com> <44393AB7.3050506@middle.net> <443A2A46.9050808@dsl.pipex.com> <443A7195.5070406@middle.net> <443AA46C.9080708@dsl.pipex.com> <443ABFE1.6030601@middle.net> <443D7015.7080707@drugphish.ch>
Reply-To: andy.furniss@dsl.pipex.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mark Butler <butlerm@middle.net>,
	"David S. Miller" <davem@davemloft.net>,
	michal.k.k.piotrowski@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from blaster.systems.pipex.net ([62.241.163.7]:31637 "EHLO
	blaster.systems.pipex.net") by vger.kernel.org with ESMTP
	id S932409AbWDLXdr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Apr 2006 19:33:47 -0400
To: Roberto Nibali <ratz@drugphish.ch>
In-Reply-To: <443D7015.7080707@drugphish.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roberto Nibali wrote:

> 
> I had the distinct pleasure of partly get involved with debugging 
> network stalls related to Linux clients (2.6.x kernel) and a Packeteer.

Dare I suggest that it could be something as trivial as it looks like 
window scaling defaults to off on SunOS 2.5.1 and it's on on Linux - 
maybe packeteer can't handle it properly. Would be an easy test to turn 
it off on the Suse boxes.

Andy.
