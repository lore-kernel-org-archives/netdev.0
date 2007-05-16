From: Jiri Kosina <jikos@jikos.cz>
Subject: Re: 2.6.21-rc7: BUG: sleeping function called from
 invalid context at net/core/sock.c:1523
Date: Wed, 16 May 2007 14:19:04 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0705161418250.25986@twin.jikos.cz>
References: <462D1B09.9050005@goop.org>
	<Pine.LNX.4.64.0704232257090.20657@twin.jikos.cz>
	<Pine.LNX.4.64.0704261625410.20657@twin.jikos.cz>
	<a781481a0705110629n7c7130c1x3a89fa958b271f20@mail.gmail.com>
	<Pine.LNX.4.64.0705161124030.25986@twin.jikos.cz>
	<a781481a0705160436s3564022aybd9b318ec0947d94@mail.gmail.com>
	<1179315904.10069.67.camel@violet>
	<a781481a0705160456q778cfb4dk67d754317d57e9bb@mail.gmail.com>
	<a781481a0705160459p2d538d7fu8096bd594d6df2f9@mail.gmail.com>
	<1179317775.10069.77.camel@violet>
Reply-To: BlueZ development <bluez-devel@lists.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, netdev@vger.kernel.org,
	Greg KH <gregkh@suse.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Cedric Le Goater <clg@fr.ibm.com>, bluez-devel@lists.sourceforge.net,
	maxk@qualcomm.com, Satyam Sharma <satyam.sharma@gmail.com>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <bluez-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1179317775.10069.77.camel@violet>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=bluez-devel>
List-Post: <mailto:bluez-devel@lists.sourceforge.net>
List-Help: <mailto:bluez-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: bluez-devel-bounces@lists.sourceforge.net
Errors-To: bluez-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, 16 May 2007, Marcel Holtmann wrote:

> since Jiri has a good test case for it, I leave it to him for testing.
> If he confirms that this fixes the locking issues, then this is
> Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

I will verify later this evening and will let you know. I am however 
pretty convinced now that this is the right fix.

Thanks,

-- 
Jiri Kosina

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
