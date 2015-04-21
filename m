From: Sage Weil <sage@newdream.net>
Subject: Re: randconfig build error with next-20150421, in net/ceph
Date: Tue, 21 Apr 2015 09:21:51 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1504210920110.18547@cobra.newdream.net>
References: <CA+r1Zhgwq-t+M8XOxDqf5synesyHODOee2gNwAJpWE+wwmAAoQ@mail.gmail.com> <20150421161613.GA29133@roeck-us.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jim Davis <jim.epost@gmail.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next <linux-next@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>, zyan@redhat.com,
	"David S. Miller" <davem@davemloft.net>,
	ceph-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	idryomov@gmail.com
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20150421161613.GA29133@roeck-us.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 21 Apr 2015, Guenter Roeck wrote:
> On Tue, Apr 21, 2015 at 08:10:44AM -0700, Jim Davis wrote:
> > Building with the attached random configuration file,
> > 
> > ERROR: "__divdi3" [net/ceph/libceph.ko] undefined!
> 
> Commit 7321f19d ("crush: straw2 bucket type with an efficient 64-bit crush_ln()").
> 
> +                       draw = ln / w;
> 
> where 'ln' is 64 bit.
> 
> Some other oddies in that patch, such as 
> 
> +#if defined(__linux__)
> +#include <linux/types.h>
> +#elif defined(__FreeBSD__)
> +#include <sys/types.h>
> +#endif
> 
> and lots of coding style violations.

Thanks for the report--we'll fix it up!

sage
