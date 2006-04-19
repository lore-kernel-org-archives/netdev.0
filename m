From: James Smart <James.Smart@Emulex.Com>
Subject: [RFC] Netlink and user-space buffer pointers
Date: Wed, 19 Apr 2006 08:57:25 -0400
Message-ID: <444633B5.5030208@emulex.com>
References: <1145306661.4151.0.camel@localhost.localdomain> <20060418160121.GA2707@us.ibm.com>
Reply-To: James.Smart@Emulex.Com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-scsi-owner@vger.kernel.org>
To: linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
In-Reply-To: <20060418160121.GA2707@us.ibm.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Folks,

To take netlink to where we want to use it within the SCSI subsystem (as
the mechanism of choice to replace ioctls), we're going to need to pass
user-space buffer pointers.

What is the best, portable manner to pass a pointer between user and kernel
space within a netlink message ?  The example I've seen is in the iscsi
target code - and it's passed between user-kernel space as a u64, then
typecast to a void *, and later within the bio_map_xxx functions, as an
unsigned long. I assume we are going to continue with this method ?

-- james s
