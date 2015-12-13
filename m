From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v2] vhost: replace % with & on data path
Date: Sun, 13 Dec 2015 02:01:22 +0200
Message-ID: <CAHp75VcnkCZUF1dP7B8G4qv-JNBah+MzZn_v-aW9i8iWUDA6TQ@mail.gmail.com>
References: <1448874894-18398-1-git-send-email-mst@redhat.com>
	<20151204201901.GB19430@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Venkatesh Srinivas <venkateshs@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151204201901.GB19430@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 4, 2015 at 10:19 PM, Venkatesh Srinivas
<venkateshs@google.com> wrote:
> On Mon, Nov 30, 2015 at 11:15:23AM +0200, Michael S. Tsirkin wrote:
>> We know vring num is a power of 2, so use &
>> to mask the high bits.
>>
>> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
>> ---
>
> The generated code switches from DIV -> masking, source is clearer as well.

First impression was why, now it seems that compiler can't predict
this for variables.
For constants it would be optimized to the same, I suppose.

>
> Tested-by: Venkatesh Srinivas <venkateshs@google.com>
>
> -- vs;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



-- 
With Best Regards,
Andy Shevchenko
