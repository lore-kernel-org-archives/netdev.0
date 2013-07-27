From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] Change request_irq() to use struct net_device *dev->name
Date: Sat, 27 Jul 2013 19:13:30 +0400
Message-ID: <51F3E39A.2060203@cogentembedded.com>
References: <1374646199-9398-1-git-send-email-pshah.mumbai@gmail.com>
	<51F07489.7010404@gmail.com>
	<CAD6i1fJO3geZ0vkHLsJEd+KedHkpC1OZVTJJskU2RAAKYBhhJQ@mail.gmail.com>
	<CAD6i1f+NYu7rcQwF-TXk4+OdjPNZwMKxxjJ9YA_+v9B6uPYq+g@mail.gmail.com>
	<CAHp75VdouA2w5WjBPJ2cX8AKvTeCNrj6pM+3SS5DzU+ARM5M3Q@mail.gmail.com>
	<CAP8WD_aKqqB4Fb4Vadj_AJ4ET5gxd+EkaCMMVvBxxqNwDjpBGg@mail.gmail.com>
	<CAHp75VeqgqVdn+zRjW+McwFQfD73NhYz4X3M4ndeDZnkFmqyEg@mail.gmail.com>
	<51F16F74.3070503@cogentembedded.com>
	<20130725183824.GA32658@blackmetal.musicnaut.iki.fi>
	<CAD6i1fKra9Z8C=jm-KYuWPwxd=u-8HMo8b=XJJOo8aS+4SdmWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: kernel-mentors@selenic.com, Ryan Mallon <rmallon@gmail.com>,
	Aaro Koskinen <aaro.koskinen@iki.fi>, netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andy Shevchenko <andy.shevchenko@gmail.com>, whiteheadm@acm.org
To: Prashant Shah <pshah.mumbai@gmail.com>
Return-path: <kernel-mentors-bounces@selenic.com>
In-Reply-To: <CAD6i1fKra9Z8C=jm-KYuWPwxd=u-8HMo8b=XJJOo8aS+4SdmWg@mail.gmail.com>
List-Unsubscribe: <http://selenic.com/mailman/options/kernel-mentors>,
	<mailto:kernel-mentors-request@selenic.com?subject=unsubscribe>
List-Archive: <http://selenic.com/pipermail/kernel-mentors>
List-Post: <mailto:kernel-mentors@selenic.com>
List-Help: <mailto:kernel-mentors-request@selenic.com?subject=help>
List-Subscribe: <http://selenic.com/mailman/listinfo/kernel-mentors>,
	<mailto:kernel-mentors-request@selenic.com?subject=subscribe>
Sender: kernel-mentors-bounces@selenic.com
Errors-To: kernel-mentors-bounces@selenic.com
List-Id: netdev.vger.kernel.org

On 27-07-2013 12:58, Prashant Shah wrote:

>>>     It's also called managed device API. In fact, I've never heard it
>>> named devres API.

> If I understood it correctly it has to just calls
> devm_request_region() with the struct device pointer and there are no
> deallocation functions to call ? It manages deallocation on it own.

    Yes.

> Regards.

WBR, Sergei
