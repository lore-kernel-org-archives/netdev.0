From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 3/6] net: bridge: break if
	__br_mdb_del	fails
Date: Thu, 18 May 2017 11:45:21 -0400
Message-ID: <87fug2yxri.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170517212709.6473-1-vivien.didelot@savoirfairelinux.com>
	<20170517212709.6473-4-vivien.didelot@savoirfairelinux.com>
	<5d8f53ea-a9de-7c76-f088-48c5357cb2a2@cumulusnetworks.com>
	<877f1edwxp.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
	<1211f3cb-c5f5-a9bd-638b-bfcb99fd1bed@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "moderated list:ETHERNET BRIDGE" <bridge@lists.linux-foundation.org>,
	kernel@savoirfairelinux.com, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1211f3cb-c5f5-a9bd-638b-bfcb99fd1bed@cumulusnetworks.com>
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

>> OK good to know. That intention wasn't obvious. I can make __br_mdb_del
>> return void instead? What about the rest of the patchset if I do so?
>
> If you make it return void we will not be able to return proper error value
> when doing a single operation (the else case). About the rest I see only some
> minor style issues, I'll comment on the respective patches. Another minor nit is 
> using switch() instead of if/else for the message types but that is really up to 
> you, I don't mind either way. :-)

Ho OK I understand better the batch vs single delete operation now.
__br_mdb_do hardly makes sense now, because we don't know which case we
are handling... But factorizing br_mdb_do still makes sense. I'll come
up with something.

Thanks,

        Vivien
