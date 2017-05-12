From: Mauro Carvalho Chehab <mchehab@s-opensource.com>
Subject: [PATCH 00/36] Convert DocBook documents to ReST
Date: Fri, 12 May 2017 10:59:43 -0300
Message-ID: <cover.1494596071.git.mchehab@s-opensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, alsa-devel@alsa-project.org,
 Takashi Iwai <tiwai@suse.de>, Jan Kiszka <jan.kiszka@siemens.com>,
 "Herton R. Krzesinski" <herton@redhat.com>,
 Alexei Starovoitov <ast@kernel.org>, "J. Bruce Fields" <bfields@fieldses.org>,
 linux-ide@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
 netdev@vger.kernel.org, Jeff Layton <jlayton@poochiereds.net>,
 Jan Kara <jack@suse.com>, Soheil Hassas Yeganeh <soheil@google.com>,
 linux-s390@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>,
 "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
 Herbert Xu <herbert@gondor.apana.org.au>, linux-scsi@vger.kernel.org,
 Jonathan Corbet <corbet@lwn.net>, Ursula Braun <ubraun@linux.vnet.ibm.com>,
 "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
 Mauro Carvalho Chehab <mchehab@s-opensource.com>,
 Peter Zijlstra <peterz@infradead.org>, Julian Anastasov <ja@ssi.bg>,
 Ingo
To: linux-kernel@vger.kernel.org,
 Linux Doc Mailing List <linux-doc@vger.kernel.org>
Return-path: <alsa-devel-bounces@alsa-project.org>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/options/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel/>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Errors-To: alsa-devel-bounces@alsa-project.org
Sender: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org

This patch series convert the following books from
DocBook to ReST:

   - filesystems
   - kernel-hacking
   - kernel-locking
   - kgdb
   - libata
   - networking
   - rapidio
   - s390-drivers
   - scsi
   - w1
   - z8530book

It also adjusts some Sphinx-pedantic errors/warnings on
some kernel-doc markups.

I also added some patches here to add PDF output for all
existing ReST books.

I did my best to check if what's there is not too outdated, but
the best is if the subsystem maintainers could check it.

After this series, there are only 4 DocBook remaining conversion:
   - librs
   - lsm
   - mtdnand
   - sh

I'll likely convert those remaining ones during this weekend.

-

This patch series is based on docs tree (next branch).
The full patch series is on this tree:

   https://git.linuxtv.org//mchehab/experimental.git/log/?h=docbook

And the HTML output at:

  http://www.infradead.org/~mchehab/kernel_docs/
  https://mchehab.fedorapeople.org/kernel_docs/  

Mauro Carvalho Chehab (36):
  docs-rst: convert kernel-hacking to ReST
  kernel-hacking: update document
  docs-rst: convert kernel-locking to ReST
  mutex, futex: adjust kernel-doc markups to generate ReST
  locking.rst: reformat locking table
  locking.rst: add captions to two tables
  locking.rst: Update some ReST markups
  docs-rst: convert kgdb DocBook to ReST
  kgdb.rst: Adjust ReST markups
  conf.py: define a color for important markup on PDF output
  docs-rst: conf.py: sort LaTeX documents in alphabetical order
  docs-rst: conf.py: remove kernel-documentation from LaTeX
  docs-rst: add crypto API book to pdf output
  docs-rst: add dev-tools book to pdf output
  docs-rst: add sound book to pdf output
  docs-rst: add userspace API book to pdf output
  docs-rst: convert filesystems book to ReST
  docs-rst: filesystems: use c domain references where needed
  fs: jbd2: make jbd2_journal_start() kernel-doc parseable
  docs-rst: don't ignore internal functions for jbd2 docs
  fs: locks: Fix some troubles at kernel-doc comments
  fs: add a blank lines on some kernel-doc comments
  fs: eventfd: fix identation on kernel-doc
  fs: jbd2: escape a string with special chars on a kernel-doc
  docs-rst: convert libata book to ReST
  libata.rst: add c function and struct cross-references
  libata: fix identation on a kernel-doc markup
  docs-rst: convert s390-drivers DocBook to ReST
  docs-rst: convert networking book to ReST
  net: skbuff.h: properly escape a macro name on kernel-doc
  net: fix some identation issues at kernel-doc markups
  docs-rst: convert z8530book DocBook to ReST
  docs-rst: convert scsi DocBook to ReST
  scsi: fix some kernel-doc markups
  docs-rst: convert w1 book to ReST
  docs-rst: convert rapidio book to ReST

 Documentation/DocBook/Makefile            |   11 +-
 Documentation/DocBook/filesystems.tmpl    |  381 -----
 Documentation/DocBook/kernel-hacking.tmpl | 1312 ------------------
 Documentation/DocBook/kernel-locking.tmpl | 2151 -----------------------------
 Documentation/DocBook/kgdb.tmpl           |  918 ------------
 Documentation/DocBook/libata.tmpl         | 1625 ----------------------
 Documentation/DocBook/networking.tmpl     |  111 --
 Documentation/DocBook/rapidio.tmpl        |  155 ---
 Documentation/DocBook/s390-drivers.tmpl   |  161 ---
 Documentation/DocBook/scsi.tmpl           |  409 ------
 Documentation/DocBook/w1.tmpl             |  101 --
 Documentation/DocBook/z8530book.tmpl      |  371 -----
 Documentation/conf.py                     |   35 +-
 Documentation/crypto/conf.py              |   10 +
 Documentation/dev-tools/index.rst         |    1 +
 Documentation/dev-tools/kgdb.rst          |  907 ++++++++++++
 Documentation/driver-api/index.rst        |    5 +
 Documentation/driver-api/libata.rst       | 1031 ++++++++++++++
 Documentation/driver-api/rapidio.rst      |  107 ++
 Documentation/driver-api/s390-drivers.rst |  111 ++
 Documentation/driver-api/scsi.rst         |  344 +++++
 Documentation/driver-api/w1.rst           |   70 +
 Documentation/filesystems/conf.py         |   10 +
 Documentation/filesystems/index.rst       |  317 +++++
 Documentation/index.rst                   |    3 +
 Documentation/kernel-hacking/conf.py      |   10 +
 Documentation/kernel-hacking/hacking.rst  |  811 +++++++++++
 Documentation/kernel-hacking/index.rst    |    5 +
 Documentation/kernel-hacking/locking.rst  | 1446 +++++++++++++++++++
 Documentation/networking/conf.py          |   10 +
 Documentation/networking/index.rst        |   18 +
 Documentation/networking/kapi.rst         |  147 ++
 Documentation/networking/z8530book.rst    |  256 ++++
 Documentation/sound/conf.py               |   10 +
 drivers/ata/libata-scsi.c                 |    7 +-
 drivers/net/phy/phy.c                     |    1 +
 drivers/scsi/scsi_scan.c                  |    7 +-
 drivers/scsi/scsi_transport_fc.c          |   18 +-
 drivers/scsi/scsicam.c                    |    4 +-
 fs/eventfd.c                              |    4 +-
 fs/fs-writeback.c                         |   12 +-
 fs/jbd2/transaction.c                     |   42 +-
 fs/locks.c                                |   18 +-
 fs/mpage.c                                |    1 +
 fs/namei.c                                |    1 +
 include/linux/mutex.h                     |    6 +-
 include/linux/netdevice.h                 |    9 +-
 include/linux/skbuff.h                    |    2 +-
 include/net/sock.h                        |    9 +-
 kernel/futex.c                            |   40 +-
 kernel/locking/mutex.c                    |    6 +-
 net/core/datagram.c                       |    2 +-
 net/core/sock.c                           |    7 +-
 53 files changed, 5764 insertions(+), 7802 deletions(-)
 delete mode 100644 Documentation/DocBook/filesystems.tmpl
 delete mode 100644 Documentation/DocBook/kernel-hacking.tmpl
 delete mode 100644 Documentation/DocBook/kernel-locking.tmpl
 delete mode 100644 Documentation/DocBook/kgdb.tmpl
 delete mode 100644 Documentation/DocBook/libata.tmpl
 delete mode 100644 Documentation/DocBook/networking.tmpl
 delete mode 100644 Documentation/DocBook/rapidio.tmpl
 delete mode 100644 Documentation/DocBook/s390-drivers.tmpl
 delete mode 100644 Documentation/DocBook/scsi.tmpl
 delete mode 100644 Documentation/DocBook/w1.tmpl
 delete mode 100644 Documentation/DocBook/z8530book.tmpl
 create mode 100644 Documentation/crypto/conf.py
 create mode 100644 Documentation/dev-tools/kgdb.rst
 create mode 100644 Documentation/driver-api/libata.rst
 create mode 100644 Documentation/driver-api/rapidio.rst
 create mode 100644 Documentation/driver-api/s390-drivers.rst
 create mode 100644 Documentation/driver-api/scsi.rst
 create mode 100644 Documentation/driver-api/w1.rst
 create mode 100644 Documentation/filesystems/conf.py
 create mode 100644 Documentation/filesystems/index.rst
 create mode 100644 Documentation/kernel-hacking/conf.py
 create mode 100644 Documentation/kernel-hacking/hacking.rst
 create mode 100644 Documentation/kernel-hacking/index.rst
 create mode 100644 Documentation/kernel-hacking/locking.rst
 create mode 100644 Documentation/networking/conf.py
 create mode 100644 Documentation/networking/index.rst
 create mode 100644 Documentation/networking/kapi.rst
 create mode 100644 Documentation/networking/z8530book.rst
 create mode 100644 Documentation/sound/conf.py

-- 
2.9.3
