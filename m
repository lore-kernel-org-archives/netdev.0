From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [PATCH 1/3] bridge: preserve random init MAC address
Date: Tue, 18 Mar 2014 20:37:35 -0700
Message-ID: <CAB=NE6UgOL_d3MYyhqiLAZw-TLsf4wDu3NTW3+Zv1rJ6Exkdhg@mail.gmail.com>
References: <1394680527-28970-1-git-send-email-mcgrof@do-not-panic.com>
	<1394680527-28970-2-git-send-email-mcgrof@do-not-panic.com>
	<20140318201056.7b876394@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kvm@vger.kernel.org, xen-devel@lists.xenproject.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20140318201056.7b876394@nehalam.linuxnetplumber.net>
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

On Tue, Mar 18, 2014 at 8:10 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Wed, 12 Mar 2014 20:15:25 -0700
> "Luis R. Rodriguez" <mcgrof@do-not-panic.com> wrote:
>
>> As it is now if you add create a bridge it gets started
>> with a random MAC address and if you then add a net_device
>> as a slave but later kick it out you end up with a zero
>> MAC address. Instead preserve the original random MAC
>> address and use it.
>
> What is supposed to happen is that the recalculate chooses
> the lowest MAC address of the slaves. If there are no slaves
> it might as well just calculate a new random value. There is
> not great merit in preserving the original defunct address.

OK I'll go and add some changes for this then.

  Luis
