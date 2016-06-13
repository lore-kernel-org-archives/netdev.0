From: Moni Shoua <monis-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 1/3] infiniband: rxe: avoid 64-bit division
Date: Mon, 13 Jun 2016 18:27:35 +0300
Message-ID: <CAG9sBKM72VKZPOGHKY_A0m6bQs3yKNLyBCLFycwbrmNYwXnaMA@mail.gmail.com>
References: <1465822509-4167617-1-git-send-email-arnd@arndb.de> <20160613131840.GJ5408@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Amir Vadai <amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Kamal Heib <kamalh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160613131840.GJ5408-2ukJVAZIZ/Y@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

thanks. will be applied to next series

On Mon, Jun 13, 2016 at 4:18 PM, Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> On Mon, Jun 13, 2016 at 02:54:53PM +0200, Arnd Bergmann wrote:
>> The rxe driver fails to build on 32-bit because of a 64-bit division:
>>
>> In function `rxe_qp_from_attr':
>> :(.text+0x53158): undefined reference to `__aeabi_uldivmod'
>>
>> We can easily avoid this division by converting the nanosecond value
>> into jiffies directly rather than converting to microseconds first.
>>
>> Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
>
> Thanks Arnd,
> All three patches are applied on topic/rxe now.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
