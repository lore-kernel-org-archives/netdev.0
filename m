From: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Subject: Re: [PATCH 33/37] sound/soc: use .dev.of_node instead of .node in
	struct of_device
Date: Mon, 5 Apr 2010 17:47:48 -0600
Message-ID: <q2tfa686aa41004051647p4c8182d0h807583d09714761a@mail.gmail.com>
References: <20100311174830.4824.19820.stgit@angua> <20100311180649.4824.10368.stgit@angua>
	<20100405230301.GF32401@fluff.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org, gregkh-l3A5Bk7waGM@public.gmane.org, benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org, jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org, dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org,
	jeremy.kerr-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org, James.Bottomley-l3A5Bk7waGM@public.gmane.org,
	broonie-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org,
	microblaze-uclinux-rVRm/Wmeqae7NGdpmJTKYQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-ide-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org
To: Ben Dooks <ben-linux-elnMNo+KYs3YtjvyW6yDsg@public.gmane.org>
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100405230301.GF32401-elnMNo+KYs3pIgCt6eIbzw@public.gmane.org>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Ben, thanks for the comment.  Reply below...

On Mon, Apr 5, 2010 at 5:03 PM, Ben Dooks <ben-linux-elnMNo+KYs3YtjvyW6yDsg@public.gmane.org> wrote:
> On Thu, Mar 11, 2010 at 11:06:50AM -0700, Grant Likely wrote:
>> .node is being removed
[...]
>> --- a/sound/soc/fsl/mpc8610_hpcd.c
>> +++ b/sound/soc/fsl/mpc8610_hpcd.c
>> @@ -202,7 +202,7 @@ static struct snd_soc_ops mpc8610_hpcd_ops =3D {
>> =A0static int mpc8610_hpcd_probe(struct of_device *ofdev,
>> =A0 =A0 =A0 const struct of_device_id *match)
>> =A0{
>> - =A0 =A0 struct device_node *np =3D ofdev->node;
>> + =A0 =A0 struct device_node *np =3D ofdev->dev.of_node;
>> =A0 =A0 =A0 struct device_node *codec_np =3D NULL;
>> =A0 =A0 =A0 struct device_node *guts_np =3D NULL;
>> =A0 =A0 =A0 struct device_node *dma_np =3D NULL;
>
> This looks like one case where an inline function would have been a
> help.

In what regard (how would you like it to look)?  The node pointer
location is very unlikely to move again, and I prefer the clarity of
direct dereferencing.

g.
