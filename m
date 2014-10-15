From: "Alexander E. Patrakov" <patrakov@gmail.com>
Subject: Re: [RFC v2 3/6] kthread: warn on kill signal if
 not OOM
Date: Thu, 16 Oct 2014 01:46:44 +0600
Message-ID: <543ECF24.3040202@gmail.com>
References: <1409899047-13045-1-git-send-email-mcgrof@do-not-panic.com>
 <20140909011059.GB11706@mtj.dyndns.org> <1410241109.2028.22.camel@jarvis.lan>
 <CAB=NE6WGAMvffGDTkN5x5Cd+YOtD-Cmo3v7_8FmJ5cvCRbFEpw@mail.gmail.com>
 <1410291346.13298.16.camel@jarvis.lan>
 <CAB=NE6U6v-GhAaZv3yXn9uVFvBvE4Uq8z7MQU8N+CyW19WpnNQ@mail.gmail.com>
 <CAG-2HqUiUksdT4UyeDsdc1Q74=2BiX2TuzzGh_hoLiO5_DOvXQ@mail.gmail.com>
 <CAB=NE6UprJH69hzc1mjqyq6PAn+7LZmX65Z8CDwUdJ73nDusHg@mail.gmail.com>
 <CAG-2HqUzCvd55mq=M3=tXbHAjc2QnVuRtbFZMWTz9k_6BmmngQ@mail.gmail.com>
 <CAB=NE6XmFaWMKuW3vJ7QMZ1BmmWrAPezTYYsqatX4mMNdMjpog@mail.gmail.com>
 <CAG-2HqWYXo+uRtOk_XW-Bi5aXcTLphEMLCMy8a2THuEg9dHPzw@mail.gmail.com>
 <CAB=NE6XS9pWmfO7xjTpLFG1OdOJ=UktbOK5pjJCK8hzfXagfXQ@mail.gmail.com>
 <CAOMFOmVSwPAbPtNzPn93QGjbXh1B3QC7B2Ahd1Qxc=gWb6H7fQ@mail.gmail.com>
 <CAG-2HqXdxHrx4OL4E0TnzA1Fb6zK6J+qowfD0RHCwviGUv-_ng@mail.gmail.com>
 <CAOMFOmW2r2SyRVLAdZTV_1wK+gRES-hQXHGUGnWA=kvv6P3KXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
 Takashi Iwai <tiwai@suse.de>, Kay Sievers <kay@vrfy.org>,
 Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
 hare <hare@suse.com>,
 Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
 Wu Zhangjin <falcon@meizu.com>,
 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
 "mpt-fusionlinux.pdl" <MPT-FusionLinux.pdl@avagotech.com>,
 Tim Gardner <tim.gardner@canonical.com>, Benjamin Poirier <bpoirier@suse.de>,
 Santosh Rastapur <santosh@chelsio.com>, Casey Leedom <leedom@chelsio.com>,
 Hariprasad S <hariprasad@chelsio.com>,
 Pierre Fersing <pierre-fersing@pierref.org>,
 Arjan van de Ven <arjan@linux.intel.com>,
 Abhijit Mahajan <abhijit.mahajan@avagotech.com>,
 systemd Mailing List <systemd-devel@lists.freedesk
To: Anatol Pomozov <anatol.pomozov@gmail.com>,
 Tom Gundersen <teg@jklm.no>
Return-path: <systemd-devel-bounces@lists.freedesktop.org>
In-Reply-To: <CAOMFOmW2r2SyRVLAdZTV_1wK+gRES-hQXHGUGnWA=kvv6P3KXQ@mail.gmail.com>
List-Unsubscribe: <http://lists.freedesktop.org/mailman/options/systemd-devel>,
 <mailto:systemd-devel-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <http://lists.freedesktop.org/archives/systemd-devel>
List-Post: <mailto:systemd-devel@lists.freedesktop.org>
List-Help: <mailto:systemd-devel-request@lists.freedesktop.org?subject=help>
List-Subscribe: <http://lists.freedesktop.org/mailman/listinfo/systemd-devel>,
 <mailto:systemd-devel-request@lists.freedesktop.org?subject=subscribe>
Errors-To: systemd-devel-bounces@lists.freedesktop.org
Sender: "systemd-devel" <systemd-devel-bounces@lists.freedesktop.org>
List-Id: netdev.vger.kernel.org

16.10.2014 01:41, Anatol Pomozov wrote:
> True. module name should be enough. In this case to debug the issue user needs:
>   - disable failing udev rule (or blacklist module?)
>   - reboot, it will let the user get into shell
>   - modprobe the failing module
>   - use sysrq-trigger to get more information about stuck process

Nitpick: this only works only if the "stuck modprobe" bug is 100% 
reproducible. Which is not a given. So it is better to collect as much 
information about the bug when it is noticed by systemd.

-- 
Alexander E. Patrakov
