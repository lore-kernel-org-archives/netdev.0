From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: TCP connection stalls under 2.6.24.7
Date: Thu, 31 Jul 2008 09:44:36 -0300
Message-ID: <20080731094436.12ec99ae@tux>
References: <47EA0DAB.7080205@securenet.de>
	<Pine.LNX.4.64.0807251613230.11302@wrl-59.cs.helsinki.fi>
	<200807251734.27743.thomas.jarosch@intra2net.com>
	<200807310939.42406.thomas.jarosch@intra2net.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: "Ilpo =?ISO-8859-1?Q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Sven Riedel <sr@securenet.de>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	David Miller <davem@davemloft.net>
To: Thomas Jarosch <thomas.jarosch@intra2net.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:13577 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750909AbYGaMom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 08:44:42 -0400
Received: by qw-out-2122.google.com with SMTP id 3so36176qwe.37
        for <netdev@vger.kernel.org>; Thu, 31 Jul 2008 05:44:41 -0700 (PDT)
In-Reply-To: <200807310939.42406.thomas.jarosch@intra2net.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 31 Jul 2008 09:39:40 +0200
Thomas Jarosch <thomas.jarosch@intra2net.com> wrote:

> Ok. Please try the latest patch Ilpo CC:ed you. Here's a link to the post:
> http://marc.info/?l=linux-netdev&m=121699478406378&w=2

	Before I try could this issue be related to some of these
kernel parameters?

echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts

echo 0 > /proc/sys/net/ipv4/conf/all/accept_source_route 

echo 0 > /proc/sys/net/ipv4/conf/all/accept_redirects 

echo 1 > /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses 

	I ask it because I decided to comment these lines (on my
NATted desktop and on the server) and until now I don't have the problem
anymore. But I'll keep testing all day and if the problem comes back
I'll try the patch ok?

> Where is the NNTP server located? At your provider?

	It's my nntp server:

nntp://news.abusar.org

	You can post test messages on grupo "u-br.teste".

	But there's an issue. My connection was stalled mainly when I
ran some application with sudo (for example fetchnews etc). Then I'd do
an nmap -sS and the connection would come back alive. Sometimes it
would be necessary a nmap on my desktop (local machine) and sometimes
on the server (news.abusar.org).

-- 
