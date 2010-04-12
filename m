From: stephen mulcahy <smulcahy@atlanticlinux.ie>
Subject: Bug#572201: forcedeth driver hangs under heavy load
Date: Mon, 12 Apr 2010 11:01:44 +0100
Message-ID: <4BC2EF88.3060203@atlanticlinux.ie>
References: <4B9E6C60.7030300@atlanticlinux.ie>	 <20100315182220.GQ2763@decadent.org.uk> <4B9F5E5E.2060209@atlanticlinux.ie>	 <1270393967.8341.11.camel@localhost> <4BBCA19C.5080204@atlanticlinux.ie> <1270942606.6179.64.camel@localhost>
Reply-To: stephen mulcahy <smulcahy@atlanticlinux.ie>, 572201@bugs.debian.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <ben@decadent.org.uk>,
 Eric Dumazet <eric.dumazet@gmail.com>,
 Ayaz Abdulla <aabdulla@nvidia.com>, 572201@bugs.debian.org
To: netdev <netdev@vger.kernel.org>
Return-path: <bounce-debian-bugs-dist=glddb-debian-bugs-dist=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.572201.B572201.127106652517034@bugs.debian.org>
In-Reply-To: <1270942606.6179.64.camel@localhost>
List-Post: <mailto:debian-bugs-dist@lists.debian.org>
List-Help: <mailto:debian-bugs-dist-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

Ben Hutchings wrote:
> Stephen Mulcahy reported a regression in forcedeth at
> <http://bugs.debian.org/572201>.  The system information and some
> diagnostic information can be found there.  Anyone able to help?

Incidentally, I also tried the 2.6.33.2 kernel with 
CONFIG_FORCEDETH_NAPI set to "y" to see if that made a difference.

It doesn't - further testing over the weekend saw 6 of 45 machines drop 
off the network with this problem. Nothing in dmesg or system logs. 
Happy to run more tests if someone can advise on what should be run.

-stephen

-- 
Stephen Mulcahy     Atlantic Linux         http://www.atlanticlinux.ie
Registered in Ireland, no. 376591 (144 Ros Caoin, Roscam, Galway)
