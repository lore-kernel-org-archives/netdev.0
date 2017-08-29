From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 0/2] enable hires timer to timeout datagram socket
Date: Tue, 29 Aug 2017 11:16:49 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD006828A@AcuExch.aculab.com>
References: <1503447027-44399-1-git-send-email-vallish@amazon.com>
 <20170822.213030.1848111782253505433.davem@davemloft.net>
 <20170827204725.GA8625@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "shuah@kernel.org" <shuah@kernel.org>,
        "richardcochran@gmail.com" <richardcochran@gmail.com>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "eduval@amazon.com" <eduval@amazon.com>,
        "anchalag@amazon.com" <anchalag@amazon.com>
To: 'Vallish Vaidyeshwara' <vallish@amazon.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170827204725.GA8625@amazon.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vallish Vaidyeshwara
> Sent: 27 August 2017 21:47
...
> I respect the decision not to upstream this patch series, however I
> wanted to provide additional details. Application wanting high
> resolution events with real guarantees is not the case, but the case
> here is regression in system call behavior:
> 
> 1) Change in system call behavior:
> strace from 4.4 test run of waiting for 180 seconds on datagram socket:
> 10:25:48.239685 setsockopt(3, SOL_SOCKET, SO_RCVTIMEO, "\264\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0", 16) = 0
> 10:25:48.239755 recvmsg(3, 0x7ffd0a3beec0, 0) = -1 EAGAIN (Resource temporarily unavailable)
> 10:28:48.236989 fstat(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 0), ...}) = 0

IMHO you should be complaining to the main kernel group who 'broke' the
timer code, not the networking group.

	David
