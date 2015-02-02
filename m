From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH v2 0/3] Restore UFO support to virtio_net devices
Date: Mon, 02 Feb 2015 10:04:09 -0500
Message-ID: <54CF91E9.5040108@redhat.com>
References: <1422646047-13168-1-git-send-email-vyasevic@redhat.com>	<20150201.221935.283572621026340671.davem@davemloft.net>
	<20150201.222834.1543634857152757099.davem@davemloft.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, mst@redhat.com, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	hannes@stressinduktion.org, ben@decadent.org.uk
To: David Miller <davem@davemloft.net>, vyasevich@gmail.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20150201.222834.1543634857152757099.davem@davemloft.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 02/02/2015 01:28 AM, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Sun, 01 Feb 2015 22:19:35 -0800 (PST)
> 
>> Series applied and queued up for -stable.
> 
> I have to revert, this breaks the build.
> 
> net/built-in.o: In function `udp6_ufo_fragment':
> udp_offload.c:(.text+0x103380): undefined reference to `ipv6_select_ident'
> 

Sorry, Dave.  I am not sure what happened since the patches in my branch build
and boot.

In any case just to make sure, I've rebased on the latest net, rebuilt and reposted
the series.

Thanks
-vlad
