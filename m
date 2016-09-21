From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: Re: [RFC] PCI: Allow sysfs control over totalvfs
Date: Wed, 21 Sep 2016 06:00:28 +0000
Message-ID: <BL2PR07MB230605ED6D5A34B6C83D29EE8DF60@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1474386588-16337-1-git-send-email-Yuval.Mintz@qlogic.com>
 <20160920193645.GA12677@nanopsycho.orion>
 <BL2PR07MB23061E60A3ABC771F05764C98DF70@BL2PR07MB2306.namprd07.prod.outlook.com>,<20160921055527.GB2078@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Chickles, Derek" <Derek.Chickles@cavium.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20160921055527.GB2078@nanopsycho.orion>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >> One of the motivations for introducing devlink interface was to allow
> >> user to pass some kind of well defined option parameters or as you cal=
l
> >> it hints to driver module. That would allow to replace module options
> >> and introduce similar possibility to pre-configure hardware on probe t=
ime.
> >> We plan to use devlink to allow user to change resource allocation for
> >> mlxsw devices.
> > >
> >Is IOV configuration something you're going to explore in the near
> >future for mlxsw devices? Or are you merely pointing out that

> No, not sriov related directly.

> >devlink could provide a superior configuration infrastrucutre and
> >should be investigated as a better alternative?

> Exactly. It is a general problem of how to pre-configure driver modules.

> >> The plan is to allow to pre-create devlink instance before driver modu=
le
> >> is loaded. Then the user will use this placeholder to do the options
> >> setting. Once the driver module is loaded, it will fetch the options
> >> from devlink core and process it accordingly.
> >
> >> I believe this is exactly what you need.

> Adding devlink support is trivial in most cases, I bet you can do it in
> couple of minutes for your driver.

I'll go and educate myself, then.
Thanks.=
