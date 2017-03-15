From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: Re: [PATCH net] bridge: ebtables: fix reception of frames
 DNAT-ed to bridge device
Date: Wed, 15 Mar 2017 15:27:20 +0100
Message-ID: <20170315142720.GU15692@otheros>
References: <20170315031811.22714-1-linus.luessing@c0d3.blue>
	<20170315102608.GB24366@breakpoint.cc>
	<20170315104211.GA24409@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Florian Westphal <fw@strlen.de>, linux-kernel@vger.kernel.org,
	coreteam@netfilter.org, netfilter-devel@vger.kernel.org,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S . Miller" <davem@davemloft.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20170315104211.GA24409@salvia>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 15, 2017 at 11:42:11AM +0100, Pablo Neira Ayuso wrote:
> I'm missing then why redirect is not then just enough for Linus usecase.

For my usecase, the MAC address is configured by the user from a
Web-UI. It may or may not be the one from the bridge device.

Besides, found it counter intuitive that DNAT did not work here
and took me some time to find out why. At least I didn't read about
any such known limitations of the dnat target in the ebtables
manpage.
