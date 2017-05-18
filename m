From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [SPAM]Re: [PATCH net-next 5/6] net: bridge: get
	msgtype from nlmsghdr	in mdb ops
Date: Thu, 18 May 2017 11:53:34 -0400
Message-ID: <87efvmf9fl.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170517212709.6473-1-vivien.didelot@savoirfairelinux.com>
	<20170517212709.6473-6-vivien.didelot@savoirfairelinux.com>
	<ee5d9736-72ec-f4fd-8e9b-2c4179687e16@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "moderated list:ETHERNET BRIDGE" <bridge@lists.linux-foundation.org>,
	kernel@savoirfairelinux.com, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <ee5d9736-72ec-f4fd-8e9b-2c4179687e16@cumulusnetworks.com>
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

Hi Nikolay,

Nikolay Aleksandrov <nikolay@cumulusnetworks.com> writes:

>> +	int msgtype = nlh->nlmsg_type;
>
> minor nits:
> nlmsg_type is a u16, also please keep the order and arrange these from longest 
> to shortest

The reverse christmas tree \o/

Hum, __br_mdb_notify takes an int type, and struct nlmsghdr defines it
as a __u16. Does u16 still make sense here instead of int?


Thanks,

        Vivien
