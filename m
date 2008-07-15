From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: TCP connection stalls under 2.6.24.7
Date: Tue, 15 Jul 2008 15:30:45 -0300
Message-ID: <20080715153045.12efaea4@tux>
References: <47EA0DAB.7080205@securenet.de>
	<200807111633.42514.thomas.jarosch@intra2net.com>
	<200807151347.23598.thomas.jarosch@intra2net.com>
	<200807151810.45942.thomas.jarosch@intra2net.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Sven Riedel <sr@securenet.de>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Thomas Jarosch <thomas.jarosch@intra2net.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <200807151810.45942.thomas.jarosch@intra2net.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 15 Jul 2008 18:10:42 +0200
Thomas Jarosch <thomas.jarosch@intra2net.com> wrote:

> Disabling tcp_sack makes no difference. To summarize the situation,
> I had two different cases of stalling TCP connections, both connecting
> to busy SMTP relays servers which probably drop some packets here and there.
> 
> I can easily reproduce the problem, so how do we go from here?

	I'm using kernel 2.6.26 and the problem has gone. No stalled
connections anymore. The problem was with 2.6.25 kernel only.


-- 
