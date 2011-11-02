From: Daniel Robbins <drobbins@funtoo.org>
Subject: Re: [PATCH] bridge: Reset IPCB on forward non-local
 packets in br_handle_frame_finish()
Date: Wed, 2 Nov 2011 13:45:29 -0600
Message-ID: <CAPDOV48k=0c1anx7DC57u0x84tUVsFDQNO6=MiT+9eEE=Egi2A@mail.gmail.com>
References: <4EB19549.4010601@parallels.com>
	<20111102123106.107f4cb8@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Vasily Averin <vvs@parallels.com>,
	"David S. Miller" <davem@davemloft.net>, devel@openvz.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20111102123106.107f4cb8@nehalam.linuxnetplumber.net>
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

On Wed, Nov 2, 2011 at 1:31 PM, Stephen Hemminger <shemminger@vyatta.com> wrote:
>
> What kernel version are you using? There were several previous fixes
> in br_netfilter to deal with this type of issue over the last year.

It's a kernel from this obscure company called Red Hat, and they
include it in this product called Red Hat Enterprise Linux 6.

Specifically, 042stab37.1 :)

-Daniel
