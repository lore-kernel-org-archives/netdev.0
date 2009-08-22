From: Simon Barber <simon@superduper.net>
Subject: Re: VLANs and bridge
Date: Sat, 22 Aug 2009 07:34:11 -0700
Message-ID: <4A9001E3.6060506@superduper.net>
References: <OFC5BA9A4A.DCCE8D0D-ONC125761A.004A7620-C125761A.004BEA17@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <OFC5BA9A4A.DCCE8D0D-ONC125761A.004A7620-C125761A.004BEA17@transmode.se>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Hi Joakim,

Look back a month or so in the archives - you'll find an email from me 
referencing a patch to make the bridge VLAN aware. It's a little old, 
and needs updating for 2.6 (it was written for 2.4) - but should not be 
much work to get it done. There is a matching patch for the brctl utility.

Simon


Joakim Tjernlund wrote:
> This is probably no news to experienced bridge and VLAN users but I just learned the
> hard way that Shared VLAN learning(SVL) isn't supported
> by the linux bridge making it impossible to support configurations described in B.1.3
> Basically the bride needs to be made VLAN aware and the VLAN code needs to be adopted
> to allow this.
>
> I figured I should mention it in case it is just an oversight. It does not look like a simple
> job though.
>
>  Jocke
>
> _______________________________________________
> Bridge mailing list
> Bridge@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/bridge
>   
