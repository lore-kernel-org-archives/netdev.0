From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
 <nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next 01/16] net: introduce upper device
	lists
Date: Wed, 15 Aug 2012 22:33:56 +0200
Message-ID: <502C07B4.6050104@gmail.com>
References: <1344871635-1052-1-git-send-email-jiri@resnulli.us>
	<1344871635-1052-2-git-send-email-jiri@resnulli.us>
	<1344877451.2733.26.camel@bwh-desktop.uk.solarflarecom.com>
	<20120813173110.GA1808@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: bridge@lists.linux-foundation.org, ursula.braun@de.ibm.com,
	john.r.fastabend@intel.com, edumazet@google.com,
	shemminger@vyatta.com, sean.hefty@intel.com, therbert@google.com,
	roland@kernel.org, linux-s390@vger.kernel.org,
	linux-rdma@vger.kernel.org, fubar@us.ibm.com, fbl@redhat.com,
	hal.rosenstock@gmail.com, faisal.latif@intel.com,
	blaschka@linux.vnet.ibm.com, sony.chacko@qlogic.com,
	linux-driver@qlogic.com, Ben Hutchings <bhutchings@solarflare.com>,
	xiyou.wangcong@gmail.com, jitendra.kalsaria@qlogic.com,
	divy@chelsio.com, gregory.v.rose@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kaber@trash.net, joe@perches.com, linux390@de.ibm.com, davem@davemloft.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20120813173110.GA1808@minipsycho.orion>
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

Le 13/08/2012 19:31, Jiri Pirko a =E9crit :
> Mon, Aug 13, 2012 at 07:04:11PM CEST, bhutchings@solarflare.com wrote:

>>> +struct netdev_upper {
>>> +	struct net_device *dev;
>>> +	bool unique;
>>
>> This needs a better name.  It doesn't really have anything to do with
>> uniqueness and doesn't ensure exclusivity.  I think that it would be
>> fine to keep the 'master' term.
>
> Hmm. I admit that "unique" I do not like too much as well. But "master"
> I like even less.
>
> This flag should ensure exclusivity. Only one upper device with this
> flag can be present at a time.

Well, can't we simply call it "upper_device"?

And as we only have a single field, this is exclusive by design.

	Nicolas.
