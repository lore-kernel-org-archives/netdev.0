From: Padraig@Linux.ie
Subject: Re: ok, which wise guy did this?
Date: Wed, 22 Jan 2003 12:15:50 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E2E8B76.5000805@Linux.ie>
References: <20030122064047.D41405@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <20030122064047.D41405@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> I just booted my spanking new P4 HT PC last night using 2.5.58
> and to my dissapointment the enumeration of the ethx devices is
> reversed. I have 5 ethernet ports on this; eth0-4 on 2.4.x are now list=
ed
> as eth4-0. This is rude.

If you depend on the order then you must explicitly name the devices
like you want. I've done something like this in the past.

ip link set dev eth0 name interface-1
ip link set dev eth1 name interface-2

I guess you could use a temp name and keep the eth[0-4]
naming if you prefer.

P=E1draig.
