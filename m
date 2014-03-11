From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] x86: bpf_jit: support negative offsets
Date: Tue, 11 Mar 2014 09:59:28 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6DA58F@AcuExch.aculab.com>
References: <1394492211-4268-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Jan Seiffert <kaffeemonster@googlemail.com>,
	Eric Dumazet <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Alexei Starovoitov' <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:43353 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754000AbaCKKAT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 06:00:19 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 18378-06 for <netdev@vger.kernel.org>;
 Tue, 11 Mar 2014 10:00:17 +0000 (GMT)
In-Reply-To: <1394492211-4268-1-git-send-email-ast@plumgrid.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From:  Alexei Starovoitov
> This is a single bit patch. Is there a leaderboard of shortest patches? ;)

The shortest patches will be the ones that invert a conditional branch.
Unless the compiler reorders the code they will be 1-bit (on most archs).
Since that is a common error, there will be a few of them.

Now a 1/2bit patch would be a challenge:-)

	David
