From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [RFC] rfkill - Add support for input key to control wireless
 radio
Date: Wed, 6 Dec 2006 23:05:46 +0100
Message-ID: <20061206230546.41519771@logostar.upir.cz>
References: <200612031936.34343.IvDoorn@gmail.com>
	<200612050027.15253.IvDoorn@gmail.com>
	<d120d5000612060637s69ff235fo85a2db923a728a00@mail.gmail.com>
	<200612062031.57148.IvDoorn@gmail.com>
	<d120d5000612061218x4eac87e0jc18409f82bb7c99c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Ivo van Doorn" <ivdoorn@gmail.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, "John Linville" <linville@tuxdriver.com>,
	"Lennart Poettering" <lennart@poettering.net>,
	"Johannes Berg" <johannes@sipsolutions.net>,
	"Larry Finger" <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S937718AbWLFWF4@vger.kernel.org>
To: "Dmitry Torokhov" <dmitry.torokhov@gmail.com>
In-Reply-To: <d120d5000612061218x4eac87e0jc18409f82bb7c99c@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 6 Dec 2006 15:18:12 -0500, Dmitry Torokhov wrote:
> On 12/6/06, Ivo van Doorn <ivdoorn@gmail.com> wrote:
> > Ok, so input device opening should not block the rfkill signal and the rfkill handler
> > should still go through with its work unless a different config option indicates that
> > userspace wants to handle the event.
> 
> I don't think a config option is a good idea unless by config option
> you mean a sysfs attribute.

What about using EVIOCGRAB ioctl for this?

 Jiri

-- 
Jiri Benc
SUSE Labs
