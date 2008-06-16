From: Patrick McHardy <kaber@trash.net>
Subject: Re: [ofa-general] Re: [PATCH v4 14/14] QLogic VNIC: sysfs
	Documentation
Date: Mon, 16 Jun 2008 10:54:25 +0200
Message-ID: <48562A41.7000304@trash.net>
References: <20080610205633.11186.45499.stgit@dale>
	<20080610210918.11186.64253.stgit@dale>
	<484F751F.7030407@trash.net>
	<c8028d330806120813q6363c3cemb4aa03ceff6547d1@mail.gmail.com>
	<48513E4E.4040601@trash.net>
	<f8ca0a150806141103r56f0530br6b5e78943ac1c92d@mail.gmail.com>
	<20080614190358.GU22807@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Amar Mudrankit <amar.mudrankit@qlogic.com>, netdev@vger.kernel.org,
	general@lists.openfabrics.org, rdreier@cisco.com,
	poornima.kamath@qlogic.com
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20080614190358.GU22807@obsidianresearch.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Jason Gunthorpe wrote:
> On Sat, Jun 14, 2008 at 11:03:08AM -0700, Roland Dreier wrote:
>>> We have linkstate/operstate for this. How is a user supposed
>>> to configure the network device when it appears at a more or
>>> less random time from his perspective?
>  
>> Well, keep in mind that this driver is for an ethernet virtual NIC
>> that is actually
>> remote across another network (an InfiniBand fabric) -- so these devices
>> can actually appear or disappear at random times by their nature.  It's a
>> similar issue to, say, a USB ethernet adapter presents -- there's no sane way
>> to have operstate set for a device that hasn't been attached yet.
> 
> I think that is only a fair analogy if the VNIC used some kind of
> hot-plug auto discovery procedure like USB does. As soon as you
> require the administrator to run a command to bind a device to a VNIC
> GID you are much more like a tunnel device and the ethernet device
> should exist from the moment the administator creates it up until the
> administator destroys it. The state of the connection to the VNIC
> should be reflected in some way other than device presence.

Fully agreed.
