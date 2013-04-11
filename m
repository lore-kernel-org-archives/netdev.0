From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 1/3] if.h: add IFF_BRIDGE_RESTRICTED flag
Date: Thu, 11 Apr 2013 07:03:23 -0400
Message-ID: <5166987B.4030501@mojatatu.com>
References: <1365442863-32394-1-git-send-email-antonio@open-mesh.com>
	<1365442863-32394-2-git-send-email-antonio@open-mesh.com>
	<CAOaVG17nHuoRsf2Kss6LnpgC-Aojcso_zLYyBa18Vn9CGGY+GA@mail.gmail.com>
	<20130409075606.GB3771@open-mesh.com>
	<51641049.3030100@mojatatu.com>
	<20130409135143.GA5177@open-mesh.com>
	<5164387D.8080700@mojatatu.com>
	<20130410165434.GB5177@open-mesh.com>
	<20130410134609.46bcaeae@nehalam.linuxnetplumber.net>
	<20130411105628.GA4717@open-mesh.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bridge@lists.linux-foundation.org" <bridge@lists.linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
To: Antonio Quartulli <antonio@open-mesh.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20130411105628.GA4717@open-mesh.com>
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

On 13-04-11 06:56 AM, Antonio Quartulli wrote:

> I just realised that :)
>
> By installing ebtables (meaning modules + userspace tool) my iperf test result
> drops from 81Mbps to 66Mbps: former without, latter with ebtables module enabled.
> I did this test between two devices connected with Fast Ethernet.
>


Please try tc like i said earlier ;->

cheers,
jamal

> I thought that most of the code is in netfilter, so shared with iptables, hence
> I expected a reasonable overhead why this is much worse.
>
> Does anybody have a clue about this? I should probably start a new thread on the
> netfilter mailing list.
>
> However this problem makes ebtables unusable at all.
>
> Suggestions are welcome :)
>
> Cheers,
>
