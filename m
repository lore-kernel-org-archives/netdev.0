From: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Subject: Re: [alsa-devel] [PATCH 13/27] drivers/net/of: don't use deprecated
	field in of_platform_driver
Date: Fri, 26 Mar 2010 12:23:54 -0600
Message-ID: <fa686aa41003261123r72bcd49bw1902d85ebf6e4d06@mail.gmail.com>
References: <20100311181604.13103.30088.stgit@angua>
	<20100311182259.13103.87535.stgit@angua>
	<ed82fe3e1003260823q5a2ba774ifd3465b41b8f0a10@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
To: Timur Tabi <timur.tabi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <ed82fe3e1003260823q5a2ba774ifd3465b41b8f0a10-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 26, 2010 at 9:23 AM, Timur Tabi <timur.tabi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> I'm seeing this error with this patch applied, when building for an mpc86=
41_hpcn
>
> =A0CC =A0 =A0 =A0drivers/net/gianfar.o
> drivers/net/gianfar.c: In function 'gfar_of_init':
> drivers/net/gianfar.c:606: error: 'struct platform_device' has no
> member named 'node'
> drivers/net/gianfar.c:644: error: 'struct platform_device' has no
> member named 'node'
> drivers/net/gianfar.c: In function 'gfar_probe':
> drivers/net/gianfar.c:891: error: 'struct platform_device' has no
> member named 'node'
> make[2]: *** [drivers/net/gianfar.o] Error 1
> make[1]: *** [drivers/net] Error 2
> make: *** [drivers] Error 2

Thanks for the testing Timur.  I missed converting that driver.  I
believe I've got that fixed now and I'll be pushing out a new tree
real-soon-now.

g.
