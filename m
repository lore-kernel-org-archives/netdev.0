From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: linux-next: Tree for Jan 4 (net/bridge)
Date: Fri, 4 Jan 2013 11:27:16 -0800
Message-ID: <20130104112716.596f9085@nehalam.linuxnetplumber.net>
References: <20130104152814.3a3cf74bdec76cea09d3e134@canb.auug.org.au>
	<50E72977.7030605@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Randy Dunlap <rdunlap@infradead.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <50E72977.7030605@infradead.org>
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

On Fri, 04 Jan 2013 11:11:51 -0800
Randy Dunlap <rdunlap@infradead.org> wrote:

> On 01/03/13 20:28, Stephen Rothwell wrote:
> > Hi all,
> > 
> > Changes since 20130103:
> > 
> 
> on i386 and x86_64:
> 
>   CC      net/bridge/br_netlink.o
> net/bridge/br_netlink.c: In function 'br_netlink_init':
> net/bridge/br_netlink.c:307:2: error: implicit declaration of function 'br_mdb_init' [-Werror=implicit-function-declaration]
> net/bridge/br_netlink.c:314:2: error: implicit declaration of function 'br_mdb_uninit' [-Werror=implicit-function-declaration]
> cc1: some warnings being treated as errors
> make[3]: *** [net/bridge/br_netlink.o] Error 1
> 
> 
> Full randconfig file is attached.
> 
> 

Problem not observed with current net-next and your configuration.
Probably already fixed.
