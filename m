From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Poor network performance x86_64.. also with 3.13
Date: Sun, 09 Feb 2014 10:14:34 -0800
Message-ID: <1391969674.10160.134.camel@edumazet-glaptop2.roam.corp.google.com>
References: <52DAD66F.7080306@dragonslave.de>
	 <20140118195026.GA15543@pd.tnic> <52DB0439.2060905@dragonslave.de>
	 <52DDA2CD.9040001@dragonslave.de> <20140120223752.GA3057@pd.tnic>
	 <20140209160511.2f67866f@Mycroft> <20140209153107.GA8614@pd.tnic>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Exner <dex@dragonslave.de>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Borislav Petkov <bp@alien8.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140209153107.GA8614@pd.tnic>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2014-02-09 at 16:31 +0100, Borislav Petkov wrote:
> On Sun, Feb 09, 2014 at 04:05:11PM +0100, Daniel Exner wrote:
> > > cat /etc/sysctl.d/net.conf
> > > net.ipv4.tcp_window_scaling = 1
> > > net.core.rmem_max = 16777216
> > > net.ipv4.tcp_rmem = 4096 87380 16777
> > > net.ipv4.tcp_wmem = 4096       1638
> > 
> > After removing those values I finally had sane iperf values.
> > No idea how those got there, perhaps they made sense when I first setup
> > the box, which is some years ago..
> 
> The only question that is left to clarify now is why do those values
> have effect on 3.12.x and not on 3.10...

tcp_rmem[2] = 16777

Come on, the 640KB barrier was broken a long time ago ;)

Feel free to investigate, I wont ;)
