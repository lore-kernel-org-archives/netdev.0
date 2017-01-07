From: peter green <plugwash@p10link.net>
Subject: bad interaction between privacy extensions, prefix lifetimes and
 protocols that maintain long-term connections.
Date: Sat, 7 Jan 2017 15:16:06 +0000
Message-ID: <9769f6b7-946c-1279-110f-15de8ec40022@p10link.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: debian-ipv6@lists.debian.org, netdev@vger.kernel.org
Return-path: <bounce-debian-ipv6=debian-ipv6=m.gmane.org@lists.debian.org>
Resent-Message-ID: <hiGf3JOVuQM.A.0nF.CgQcYB@bendel>
List-URL: <https://lists.debian.org/debian-ipv6/>
List-Post: <mailto:debian-ipv6@lists.debian.org>
List-Help: <mailto:debian-ipv6-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-ipv6-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-ipv6-request@lists.debian.org?subject=unsubscribe>
List-Archive: https://lists.debian.org/msgid-search/9769f6b7-946c-1279-110f-15de8ec40022@p10link.net
List-Id: netdev.vger.kernel.org

I just switched my main machine to a new one. After doing so I noticed my connections to IRC were dropping about once per hour.

The old machine had been running a mixed mess of Debian versions while the new machine is running Debian stretch. A critical difference between the old and new machines is that the old machine had privacy extensions disabled while the new machine had them enabled.

Disabling privacy extensions solved the issue but obviously reveals the MAC address of my new machine to the world which is undesirable.

My ISP (a major provider in the UK) router sets a relatively short valid_lft of about 1 hour. Presumably so any changes to the ISP-allocated address will be picked up quickly by clients.

For the main MAC-based address the valid_lft is always short but it is updated by new RAs so the address remains valid.

However privacy addresses inherit their valid_lft from the main MAC-based address and unlike the main address it is not updated causing the addresses to time out. I believe that the timeout of these privacy addresses is what is causing my repeated disconnections from IRC.
