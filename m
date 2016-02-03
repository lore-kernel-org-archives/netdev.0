From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] virtio_net: add ethtool support for set and
	get of settings
Date: Thu, 4 Feb 2016 10:53:07 +1100
Message-ID: <20160204105307.62e6c934@samsung9>
References: <1454417480-28672-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	netdev@vger.kernel.org, Roopa Prabhu <roopa@cumulusnetworks.com>,
	virtualization@lists.linux-foundation.org, davem@davemloft.net
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1454417480-28672-1-git-send-email-razor@blackwall.org>
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

On Tue,  2 Feb 2016 13:51:20 +0100
Nikolay Aleksandrov <razor@blackwall.org> wrote:

> +static bool virtnet_validate_speed(u32 speed)
> +{
> +	switch (speed) {
> +	case SPEED_10:
> +	case SPEED_100:
> +	case SPEED_1000:
> +	case SPEED_2500:
> +	case SPEED_5000:
> +	case SPEED_10000:
> +	case SPEED_20000:
> +	case SPEED_25000:
> +	case SPEED_40000:
> +	case SPEED_50000:
> +	case SPEED_56000:
> +	case SPEED_100000:
> +	case SPEED_UNKNOWN:
> +		return true;
> +	}
> +
> +	return false;
> +}

Why limit to only known values. This switch() will get out of
date when some vendor introduces 64G or some other weird value.
